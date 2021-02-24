page 50004 "FM Apartment List"
{
    ApplicationArea = All;
    Caption = 'Apartments';
    CardPageID = "FM Apartment Card";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Apartment,Navigate';
    SourceTable = "FM Apartment";
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
                field("Description"; "Description")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    
                    trigger OnValidate()
                    begin
                    	CurrPage.SaveRecord;
                    end;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                }
                field("Search Description"; "Search Description")
                {
                	ApplicationArea = All;
                	Importance = Additional;
                }
                field(Floor; Floor)
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
            group("&Apartment")
            {
                Caption = '&Apartment';
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const(Apartment),
                                  "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
    }
}
