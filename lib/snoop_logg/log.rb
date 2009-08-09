module SnoopLogg
  class Log < Array
    
    def record(signature, type, data)
      self << [signature, type, data]
    end
    
    # TODO: develop asynchronous storage in PStore
    
  end
end
