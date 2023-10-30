def construct_date:
    # Fix up the timestamp format and change to canonical form:
    {
        "$date": (. | sub(" "; "T") + "Z")
    };
    
._id = .id
| .createdOn |= construct_date      # Convert createdOn to canonical form
| .updatedOn |= construct_date      # Convert updatedOn to canonical form
| del(.id)