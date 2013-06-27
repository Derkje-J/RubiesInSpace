require_relative '../interface/iship'

#
#
class Ship

	attr_reader :interface, :data, :crew, :location, :owner
	attr_accessor :result
	
	##
	#
	#
	def initialize( data = {} )
	
		@resources = {
			:deuterium => {
				:value => 500,
				:capacity => 5000
			}
		}
		
		@stats = {
			:speed => 1,
			:efficiency => 5
		}
		
		@result = nil
		@position = nil
		
		@actions = [ nil ]
		@events = []
		@action_progression = 1
		
		@data = data
		@interface = IShip.new self
	end
	
	#
	#
	def identifier
		self.object_id
	end
	
	##
	#
	def dead?()
		amount_of( :deuterium ) <= 0
	end
	
	##
	#
	def busy?()
		@action_progression < 1
	end
	
	#
	#
	def donate( owner, crew )
		@owner = owner
		@crew = crew
		@crew.board @interface
	end
	
	#
	#
	def amount_of( resource = :deuterium )
		@resources[ resource ][ :value ]
	end
	
	#
	#
	def capacity( resource = :deuterium )
		@resources[ resource ][ :capacity ]
	end
	
	#
	#
	def collect( amount, resource = :deuterium )
		before_amount = amount_of( resource )
		@resources[ resource ][ :value ] = [ amount_of( resource ) + amount, capacity( resource ) ].min
		return  amount_of( resource ) - before_amount
	end
	
	#
	#
	def consume( amount, resource = :deuterium )
		before_amount = amount_of( resource )
		@resources[ resource ][ :value ] = [ amount_of( resource ) - amount, 0 ].max
		return before_amount - amount_of( resource )
	end
	
	#
	#
	def position
		@location.identifier
	end
	
	#
	#
	def leave
		@location.leave self if @location
	end
	
	#
	#
	def travel( node )
		@location = node
	end
	
	#
	#
	def join
		@location.join self if @location
	end
	
	#
	#
	def damage( value )
		consume value
	end
	
	#
	#
	def stat( resource )
		@stats[ resource ]
	end
	
	#
	#
	def current
		@actions[ 0 ]
	end
	
	##
	#
	#
	def queue( action )
		@actions.push action
	end
	
	##
	#
	#
	def advance
		action = @actions.shift
		@actions = [ nil ] if @actions.empty?
		return action
	end
	
	##
	#
	#
	def duration=( duration )
		@action_progression = 0
		@action_duration = duration
	end
	
	##
	#
	#
	def progress
		@action_progression += 1.to_f / @action_duration
		return !busy?
	end
	
	##
	#
	#
	def progress_duration
		return @action_progression * @action_duration
	end
	
	##
	#
	#
	def clear_queue
		@actions = []
	end
	
	##
	#
	#
	def scan( tech = {} )
		return {
			:owner => owner.identifier,
		}
	end
	
	def to_s
		@interface.to_s
	end

end