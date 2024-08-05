use rustler::{Encoder, Env, Error, Term, Decoder, MapIterator};
use jexl_eval::{Evaluator};
use serde_json::{json as value, Value};
use anyhow::anyhow;

rustler::atoms! {
    nil,
    error
}

fn sqrt_transform(v: &[Value]) -> Result<Value, anyhow::Error> {
    let num = v
        .first()
        .expect("There should be one argument!")
        .as_f64()
        .expect("Should be a valid number!");
    Ok(value!(num.sqrt() as u64))
}

fn answer_transform(context: &Value, v: &[Value]) -> Result<Value, anyhow::Error> {
    if v.len() < 1 || v.len() > 2 {
        return Err(anyhow!("Expected one or two arguments!"));
    }

    let key = v[0].as_str()
        .ok_or_else(|| anyhow!("First argument should be a valid string!"))?;

    let default_value = v.get(1).cloned();

    match context.get(key) {
        Some(value) => Ok(value.clone()),
        None => match default_value {
            Some(default) => Ok(default),
            None => Err(anyhow!("Key '{}' not found in context and no default value provided!", key)),
        },
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn eval_jexl<'a>(env: Env<'a>, jexl_string: String, context_term: Term<'a>) -> Result<Term<'a>, Error> {
    // Decode the context term from Elixir to serde_json::Value
    let context = term_to_json(context_term)?;

    let context_clone = context.clone();
    let evaluator = Evaluator::new()
        .with_transform("sqrt", sqrt_transform)
        .with_transform("answer", move |v| answer_transform(&context_clone, v));

    match evaluator.eval_in_context(&jexl_string, context) {
        Ok(result) => Ok(convert_to_term(env, result)),
        Err(err) => Err(Error::Term(Box::new(err.to_string()))),
    }
}

fn term_to_json(term: Term) -> Result<Value, Error> {
    if term.is_atom() {
        Ok(Value::String(term.atom_to_string()?.to_string()))
    } else if term.is_number() {
        if let Ok(i) = term.decode::<i64>() {
            Ok(Value::Number(i.into()))
        } else if let Ok(f) = term.decode::<f64>() {
            Ok(Value::Number(serde_json::Number::from_f64(f).unwrap()))
        } else {
            Err(Error::BadArg)
        }
    } else if term.is_binary() {
        Ok(Value::String(term.decode::<String>()?))
    } else if term.is_list() {
        let list: Vec<Term> = term.decode()?;
        let json_list: Result<Vec<Value>, Error> = list.into_iter().map(term_to_json).collect();
        Ok(Value::Array(json_list?))
    } else if term.is_map() {
        let map: MapIterator = term.decode()?;
        let json_map: Result<serde_json::Map<String, Value>, Error> = map.into_iter()
            .map(|(k, v)| {
                let key = if k.is_atom() {
                    k.atom_to_string()?
                } else {
                    k.decode::<String>()?
                };
                let value = term_to_json(v)?;
                Ok((key, value))
            })
            .collect();
        Ok(Value::Object(json_map?))
    } else {
        Err(Error::BadArg)
    }
}

fn convert_to_term<'a>(env: Env<'a>, value: Value) -> Term<'a> {
    match value {
        Value::Null => nil().encode(env),
        Value::Bool(b) => b.encode(env),
        Value::Number(num) => {
            if let Some(i) = num.as_i64() {
                i.encode(env)
            } else if let Some(u) = num.as_u64() {
                u.encode(env)
            } else if let Some(f) = num.as_f64() {
                f.encode(env)
            } else {
                error().encode(env)
            }
        }
        Value::String(s) => s.encode(env),
        Value::Array(arr) => {
            let terms: Vec<Term> = arr.into_iter().map(|v| convert_to_term(env, v)).collect();
            terms.encode(env)
        }
        Value::Object(obj) => {
            let map: Vec<(Term, Term)> = obj.into_iter()
                .map(|(k, v)| (k.encode(env), convert_to_term(env, v)))
                .collect();
            map.encode(env)
        }
    }
}

rustler::init!("Elixir.Carumba.Jexl", [eval_jexl]);