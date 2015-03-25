# encoding: utf-8
class Fluent::UTFValidator < Fluent::Output
	Fluent::Plugin.register_output 'utf8_validator', self

	config_param :append_tag_valid, :string, :default => nil		# If there were no invalid utf8 characters, optionally tag the output
	config_param :append_tag_invalid, :string, :default => nil		# If there were found and escaped characters, append a tag indicating that it was modified
	config_param :post_tag_prefix, :string, :default => 'validated' 	# A validated message will be re-emmited after processing with this top level tag.
	config_param :deep_validate, :bool, :default => true			# Validate children embedded records on the JSON object
	config_param :replacement_character, :string, :default => '??'		# Prepended escape character for non-valid characters
	config_param :key_name, :string, :default => 'utf8_modified'		# A top level key name to store a boolean if the record has been modified

	def configure conf
		super
		@invalidCharacterFound = false
  	end

  	def emit tag, es, chain
		@invalidCharacterFound = false

    		es.each do |time, record|
			starttime = Time.now
      			new_record = validate_record record

    			if @invalidCharacterFound
      				# Emit a new tag to show utf8 characters have been escaped
				if(@append_tag_invalid)
					new_tag = "#{tag}.#{@append_tag_invalid}".sub(/^\./, '')
					log.warn "Invalid utf-8 characters found in record. appending #{@append_tag_invalid}"
				else
					new_tag = tag
				end

				# Append a top level field of the key_name
				new_record[@key_name]  = true
			else
				# Mark the record as valid
				if(@append_tag_valid)
					new_tag = "#{tag}.#{@append_tag_valid}".sub(/^\./, '')
				else
					new_tag = tag
				end

    				chain.next
      			end

			new_tag = "#{@post_tag_prefix}.#{new_tag}"
			endtime = Time.now
			new_record['debug_record_time'] = endtime - starttime
      			Fluent::Engine.emit new_tag, time, new_record
    		end 
  	end

	# Validate a string-type record for non-utf8 characters
  	def validate_record record
		new_record = {}

		record.each do |key, value|
			if value.is_a? String
				value = validate_string value
			end

			# Recurse into child record	
			if @deep_validate
				if value.is_a? Hash
					value = validate_record value
				elsif value.is_a? Array
					value = value.map { |v| v.is_a?(Hash) ? validate_record(v) : v }
				end
			end

			new_record[key] = value
		end

		new_record
	end
	
	# Recursively validate a string record and escape non-utf8 characters
	def validate_string string
		return string if string.valid_encoding?

		new_string = ""

		str_length = string.length
		midpoint = str_length/2 - 1

		if string.length <= 1
			if !string.valid_encoding?
				new_string = '??' + string.dump[3..4]
				@invalidCharacterFound = true
			else
				new_string = string
			end
		else
			new_string = validate_string(string[0..midpoint]) + validate_string(string[midpoint+1..str_length-1])  
		end

		new_string
	end
end
