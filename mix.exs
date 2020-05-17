defmodule Banshee.MixProject do
  use Mix.Project

  def project do
    [ app: :banshee,
      version: "0.1.0",
      elixir: "~> 1.6", # guessing, locally only testing on 1.10
      deps: [{:stream_data, "~> 0.5", only: [:dev, :test]}],
    ]
  end

  def application, do: []

end
