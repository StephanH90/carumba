defmodule Carumba.Test.Factory do
  use Smokestack

  alias Carumba.CarumbaForm.Document
  alias Carumba.CarumbaForm.Form
  alias Carumba.CarumbaForm.Question

  factory Document do
  end

  factory Form do
    attribute :slug, &Faker.Internet.slug/0
  end

  factory Question do
    attribute :slug, &Faker.Internet.slug/0
    attribute :is_required?, choose([true, false])
  end
end
