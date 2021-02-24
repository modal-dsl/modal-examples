page 50025 "LM Library Users"
{
    ApplicationArea = All;
    Caption = 'Library Users';
    PageType = List;
    SourceTable = "LM Library User";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
            	ShowCaption = false;
                field("Code"; "Code")
                {
                    ApplicationArea = All;
                }
                field("Name"; "Name")
                {
                	ApplicationArea = All;
                	Importance = Promoted;
                	ShowMandatory = true;
                	
                	trigger OnValidate()
                	begin
                		CurrPage.SaveRecord;
                	end;
                }
                field("Name 2"; "Name 2")
                {
                	ApplicationArea = All;
                	Importance = Additional;
                	Visible = false;
                }
                field("Search Name"; "Search Name")
                {
                	ApplicationArea = All;
                	Importance = Additional;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }
}
