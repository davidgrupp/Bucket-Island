defmodule BucketIsland.PageView do
  use BucketIsland.Web, :view

  def get_pretty_type("bucket_island"), do: "Bucket Island"
  def get_pretty_type("other_island"), do: "Other Islands"
  def get_pretty_type("forest"), do: "Forest"
  def get_pretty_type("mountain"), do: "Mountain"
  def get_pretty_type("plains"), do: "PLains"
  def get_pretty_type("swamp"), do: "Swamp"

end
