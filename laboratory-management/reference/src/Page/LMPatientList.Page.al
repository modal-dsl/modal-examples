page 50044 "LM Patient List"
{
    ApplicationArea = All;
    Caption = 'Patients';
    CardPageID = "LM Patient Card";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Patient,Navigate';
    SourceTable = "LM Patient";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("No."; "No.")
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
                field(Gender; Gender)
                {
                	ApplicationArea = All;
                }
                field(Birthday; Birthday)
                {
                	ApplicationArea = All;
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

    actions
    {
        area(navigation)
        {
            group("&Patient")
            {
                Caption = '&Patient';
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const(Patient),
                                  "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
    }
}
