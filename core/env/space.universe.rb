require_relative 'space.asteroid'
require_relative 'space.star'
require_relative 'space.planet'
require_relative 'space.planet.laboratory'
require_relative 'space.planet.factory'
require_relative 'space.node'
require_relative 'space.path'

module Space

	##
	# This is space. This is where the rubies are!
	#
	class Universe
		
		attr_reader :birthdate, :nodes, :configuration
		
		##
		#
		#
		VERSION  = 1
		
		##
		#
		#
		ENTROPY = 4
		
		##
		#
		#
		UNIVERSE = {
			
			##
			# original: 48315.6
			# 4 = 24 - 20
			# 8 = season / version
			# 315 = indication in season
			# 6 = day
			#
			# here: 48315.6
			# 
			:stardate => {
				:century =>	24,
				:season => VERSION
			},
			
			##
			# The number of nodes
			:size => 64,
			
			##
			# The ratios of the types 
			:ratios => {
				:stars => 9,
				:planets => 4
			},
			
			##
			# The distances between nodes
			:distances => {
				:min => 10,
				:max => 50,
				:connecting => 100
			},
			
			##
			# The connectivity of the graph
			:connectivity => {
				:closed => true,
				
				##
				# Nodes + Faces - Connections = 1.
				# :size / :faces = number of faces
				:faces => 3
			},
			
			##
			#
			:dice => {
				
				##
				# Chance of stars without planets 
				:lonely_star => 5,
				
				##
				# Chance of asteroid not being a traveller
				:sparse_asteroid => 4
			},
			
			##
			#
			:variance => 15
				
		}
		
		##
		# Creates space from a set of options
		#
		def initialize( options )
			
			##
			# Lets test the options and exist early
			#
			unless options[ :secrets ].is_a? Array
				raise ArgumentError.new "I really need some secrets"
			end
			
			##
			# The birthdate of the universe. We use this for a registration time of the game
			# but also to generate the universe. However, we wouldn't want the player to know
			# what the time is, so what we do is let the players give a secret ( like file name ).
			# A player can now still figure out the seeding process, but doing so is an achievement.
			#
			@birthdate = options[ :birthdate ] || Time.now()
			
			##
			# Here build the universe blueprint
			#
			@configuration = hash_defaults( options[ :universe ] || {} , UNIVERSE )
			
			##
			# Time to build that randomizer.
			#
			@seed = build_seed( options[ :secrets ].sort.join( '+' ) + @birthdate.to_i.to_s )
			
			##
			#
			#
			@@randomizer = Random.new @seed
		end
		
		##
		# Fill with nodes
		#
		def fill( nodes ) 
			@nodes = {}
			nodes.each do |n|
				@nodes[ n.identifier ] = n
			end
							
			@@logger = {}
		end
		
		##
		# Get a random spawn node
		#
		def get_spawn_node
			planets = @nodes.values.select { | n | n.is_a? Planet }
			return planets[ rand planets.length ].identifier
		end
		
		##
		# Gets a specific node
		#
		def node( id )
			@nodes[ id ]
		end
		
		##
		# Fills the defaults hash with values if the keys are present
		#
		def hash_defaults( values, defaults )
			results = {}
			defaults.each_pair { |key, value|
				results[ key ] = if value.is_a? Hash
					hash_defaults( values[ key ] || {}, value )
				else
					values[ key ] || value
				end
			}
			return results
		end
		
		##
		# Gets a number of random bytes
		#
		def self.bytes( n )
			result = []
			( @@randomizer.bytes n ).each_char { |c| result.push c.ord }
			return result
		end
		
		##
		# Gets a random number for a range or max value
		#
		def self.rand( arg = nil )
			return @@randomizer.rand if arg.nil?
			return @@randomizer.rand arg
		end
		
		##
		#
		#
		def self.log( args )
			puts args
		end
		
		#
		#
		#
		def self.timestamped( t, args )
			log "Stardate #{ stardate t }: #{ args }"
			( @@logger[ t ] ||= [] ).push args
		end
		
		def self.logger
			@@logger
		end
		
		#
		#
		#
		def self.stardate( t )
			century = UNIVERSE[ :stardate ][ :century ] * 10 + UNIVERSE[ :stardate ][ :season ] - 200
			return century * 1000 + t.to_f / 10
		end
			
		protected
		##
		# Builds the seed for this universe
		# 
		def build_seed( seed_string )
			result = ""
			seed_string.each_byte { | ord | result += ord.to_s }
			return result.to_i % ( 2 ** 32 ) 
		end	
	end
	
end