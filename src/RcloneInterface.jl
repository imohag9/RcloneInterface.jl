module RcloneInterface

include("core.jl")
include("commands/sync.jl")
include("commands/copy.jl")
include("commands/move.jl")  
include("commands/ls.jl")
include("commands/delete.jl")   

include("commands/check.jl")    
include("commands/dedupe.jl")
include("commands/miscellaneous.jl")   

export rclone_exe,
       rclone_copy,
       rclone_sync,
       rclone_move,
       rclone_ls,
       rclone_delete,
       rclone_check,
       rclone_dedupe,
       rclone_size,      
       rclone_tree,      
       rclone_version,   
       rclone_help    

end
