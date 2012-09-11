# class providing safe mechanism for unique IDs for amfetamine objects
class IdPool
  @id = 0

  def self.next
    @id += 1
  end

  def self.last
    @id
  end
end
