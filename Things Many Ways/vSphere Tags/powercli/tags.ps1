#Tag Categories
New-TagCategory -Name "costcentre" -Description "Created with PowerCLI" -Cardinality "MULTIPLE" -EntityType "VirtualMachine", "Datastore"
New-TagCategory -Name "environment" -Description "Created with PowerCLI" -Cardinality "SINGLE" -EntityType "VirtualMachine", "Datastore"
New-TagCategory -Name "nsx-tier" -Description "Created with PowerCLI" -Cardinality "MULTIPLE" -EntityType "VirtualMachine"


$TagCategories = @(
    [pscustomobject]@{Name = "costcentre"; Cardinality = "MULTIPLE"; EntityType = "VirtualMachine", "Datastore" }
    [pscustomobject]@{Name = "environment"; Cardinality = "SINGLE"; EntityType = "VirtualMachine", "Datastore" }
    [pscustomobject]@{Name = "nsx-tier"; Cardinality = "MULTIPLE"; EntityType = "VirtualMachine" }
)

foreach ($Category in $TagCategories) {
    New-TagCategory -Name $Category.Name -Cardinality $Category.Cardinality -EntityType $Category.EntityType -Description "Created with PowerCLI"
}


#Tags
New-Tag -Name "0001" -Category "costcentre" -Description "Created with PowerCLI"
New-Tag -Name "production" -Category "environment" -Description "Created with PowerCLI"
New-Tag -Name "web" -Category "nsx-tier" -Description "Created with PowerCLI"

$Tags = @(
    [pscustomobject]@{Name = "0001"; Category = "costcentre" }
    [pscustomobject]@{Name = "0002"; Category = "costcentre" }
    [pscustomobject]@{Name = "0003"; Category = "costcentre" }
    [pscustomobject]@{Name = "0004"; Category = "costcentre" }
    [pscustomobject]@{Name = "environment"; Category = "environment" }
    [pscustomobject]@{Name = "production"; Category = "environment" }
    [pscustomobject]@{Name = "pre-production"; Category = "environment" }
    [pscustomobject]@{Name = "test"; Category = "environment" }
    [pscustomobject]@{Name = "development"; Category = "environment" }
    [pscustomobject]@{Name = "web"; Category = "nsx-tier" }
    [pscustomobject]@{Name = "app"; Category = "nsx-tier" }
    [pscustomobject]@{Name = "data"; Category = "nsx-tier" }
)

foreach ($Tag in $Tags) {
    New-Tag -Name $Tag.Name -Category $Tag.Category -Description "Created with PowerCLI"
}
