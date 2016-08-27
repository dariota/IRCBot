class RingBuffer < Array
	attr_reader :max_size

	def initialize(max_size, enum = nil)
		@max_size = max_size
		@next = -1
		enum.each { |e| self << e } if enum
	end

	def <<(el)
		@next = (@next + 1) % @max_size
		self[@next] = el
		self
	end

	def each
		for i in @next.downto(0)
			yield self[i]
		end
		for i in (self.size - 1).downto(@next + 1)
			yield self[i]
		end
		nil
	end

	alias :push :<<
end
