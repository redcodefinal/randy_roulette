require "./randy_roulette/pornhub"

module RandyRoulette
  VERSION = "0.0"

  def self.make_seed_hash : Hash(Symbol, Int32)
    hash = {} of Symbol => Int32
    hash[:category] = Random.rand(1_000_000)
    hash[:video] = Random.rand(1_000_000_000)
    hash
  end

  def self.get_video(category = nil)
    seed = make_seed_hash

    categories = PornHub.get_categories

    # choose a random category if nil
    seed[:category] %= categories.keys.size
    if category.nil?
      category = categories.keys[seed[:category]]
    end

    max_videos = PornHub.get_max_videos(categories[category])

    seed[:video] %= max_videos

    PornHub.get_video(categories[category], seed[:video])
  end
end
