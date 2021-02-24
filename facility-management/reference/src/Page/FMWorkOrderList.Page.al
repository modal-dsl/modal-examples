page 50006 "FM Work Order List"
{
    ApplicationArea = All;
    Caption = 'Work Orders';
    CardPageID = "FM Work Order";
    DataCaptionFields = "Apartment No.";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Posting,Print/Send,Work Order,Navigate';
    SourceTable = "FM Wrk. Ord. Header";
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
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Apartment No."; "Apartment No.")
                {
                    ApplicationArea = All;
                }
                field("Apt. Description"; "Apt. Description")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ShowMandatory = true;
                    
                }
                field("Apt. Description 2"; "Apt. Description 2")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Visible = false;
                }
                field("Apt. Address"; "Apt. Address")
                {
                	ApplicationArea = All;
                	QuickEntry = false;
                }
                field("Apt. Address 2"; "Apt. Address 2")
                {
                	ApplicationArea = All;
                	QuickEntry = false;
                }
                field("Apt. City"; "Apt. City")
                {
                	ApplicationArea = All;
                	QuickEntry = false;
                }
                field("Apt. County"; "Apt. County")
                {
                	ApplicationArea = All;
                	QuickEntry = false;
                }
                field("Apt. Post Code"; "Apt. Post Code")
                {
                	ApplicationArea = All;
                	QuickEntry = false;
                }
                field("Apt. Country/Region Code"; "Apt. Country/Region Code")
                {
                	ApplicationArea = All;
                	QuickEntry = false;
                }
                field("Mt. Wk. Code"; "Mt. Wk. Code")
                {
                	ApplicationArea = All;
                }
                field("Mt. Wrk. Name"; "Mt. Wrk. Name")
                {
                	ApplicationArea = All;
                	Importance = Promoted;
                	ShowMandatory = true;
                	
                }
                field("Mt. Wrk. Name 2"; "Mt. Wrk. Name 2")
                {
                	ApplicationArea = All;
                	Importance = Additional;
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
            }
        }
    }

	actions
    {
        area(navigation)
        {
            group("Work Order")
            {
                Caption = 'Work Order';
                Image = "Order";
                action("&Apartment Card")
                {
                    ApplicationArea = All;
                    Caption = '&Apartment Card';
                    RunObject = Page "FM Apartment Card";
                    RunPageLink = "No." = FIELD("Apartment No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about the Apartment.';
                }
                action(Comments)
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "FM Apartment Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Work Order"),
                    			  "No." = field("No."),
                                  "Document Line No." = const(0);
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
    }
}
