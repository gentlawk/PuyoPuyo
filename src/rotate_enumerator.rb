#==============================================================================#
#                             rotate_enumerator.rb                             #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
module Enumerable
  def rotate_each
    enum = self.each
    def enum.next
      super rescue self.rewind.next
    end
    return enum
  end
end
