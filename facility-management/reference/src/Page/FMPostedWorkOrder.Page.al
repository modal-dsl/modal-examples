page 50009 "FM Posted Work Order"
{
    Caption = 'Posted Work Order';
    InsertAllowed = false;
    Editable = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Posted Work Order,Correct,Print/Send,Navigate';
    RefreshOnActivate = true;
    SourceTable = "FM Posted Work Order Header";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Apartment No."; "Apartment No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    QuickEntry = false;
                }
                field("External Document No."; "External Document No.")
                {
                	ApplicationArea = All;
                	Importance = Promoted;
                }
                field(DocumentDate; "Document Date")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("Posting Description"; "Posting Description")
                {
                    ApplicationArea = All;
                    Visible = false;
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
                field("Finish Until"; "Finish Until")
                {
                	ApplicationArea = All;
                }
                field("Requested By"; "Requested By")
                {
                	ApplicationArea = All;
                }
            }
            part("FM Posted Wrk. Ord. Subf."; "FM Posted Wrk. Ord. Subf.")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("No.");
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
            group("Posted Work Order")
            {
                Caption = 'Posted Work Order';
                Image = "Order";
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "FM Apartment Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Posted Work Order"),
                    			  "No." = field("No."),
                                  "Document Line No." = const(0);
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
        area(processing)
        {
        	action(Navigate)
        	{
        		ApplicationArea = All;
        		Caption = '&Navigate';
        		Image = Navigate;
        		Promoted = true;
        		PromotedCategory = Category4;
        		ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';
        		
        		trigger OnAction()
        		begin
        			Navigate();
        		end;
        	}
        }
    }
}
