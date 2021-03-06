module Generators

	##
	# Random words from simple rules (see datafiles); recursive info on datafile 
	# format can be found in the English rulset by Chris Pound, pound@rice.edu
	# after Mark Rosenfelder's Pascal version.
	#
	# Modified and ported to Ruby by Derk-Jan Karrenbeld. Added capitalisation.

	class Werd

		@@cache = {}
		
		##
		# Runs the werd generator
		# filename is the name of the file
		# number is the number of results
		# randomizer is the randomizer to use
		def	self.run( filename, number, randomizer = Random, override = false )
		
			@@randomizer = randomizer
			
			if override || @@cache[ filename ].nil?
				@@cache[ filename ] = WerdGenerator::Data.new filename
			end
			
			data = @@cache[ filename ] 
			number.times do
				yield data.fetch
			end
		end
		
		##
		#
		#
		def self.rand( n )
			@@randomizer.rand n
		end
		
		##
		#
		#
		class Data 

			##
			#
			#
			def initialize( filename, key = ' ' )
				@contents = {}
				@key = key
				
				File.open( filename, "r") do | infile |
					while ( line = infile.gets )
						if ( match = /^([A-Z]):(.*)$/.match line )
							@key = match[ 1 ] if @key == ' '
							@contents[ match[ 1 ] ] = match[ 2 ]
						end
					end
				end
			end

			##
			#
			# 
			def parse( key )

				groups = @contents[ key ].split ' '
				result = groups[ WerdGenerator.rand groups.length ].clone
				if ( matches = result.scan( /([A-Z])/ ) )
					for match in matches
						result.sub! match[ 0 ], parse( match[ 0 ] )
					end
				end

				result = result.gsub( /_/, ' ' )
				
				if ( matches = result.scan( /([a-z]+)!/ ) )
					for match in matches
						result.sub! "#{match[ 0 ]}!", match[ 0 ].capitalize
					end
				end
				result = result.gsub( /\\!/, '!' )
				return result
			end
			
			##
			#
			#
			def fetch( key = nil )
				parse key.nil? ? @key : key
			end
		end
	end

end