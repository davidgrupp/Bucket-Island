defmodule BucketIsland.PageView do
  use BucketIsland.Web, :view

  def get_pretty_type("bucket_island"), do: "Bucket Island"
  def get_pretty_type("other_island"), do: "Other Islands"
  def get_pretty_type("forest"), do: "Forest"
  def get_pretty_type("mountain"), do: "Mountain"
  def get_pretty_type("plains"), do: "Plains"
  def get_pretty_type("swamp"), do: "Swamp"

  def to_json(obj), do: Poison.encode!(obj)

  def get_team_level(click_level), do: trunc(:math.log10(click_level)) + 1

  def get_level_progress(click_level) do
    current_progres = get_team_level(click_level)
    max_level_progress = :math.pow(10, get_team_level(click_level))
    100 * click_level / max_level_progress
  end
end
