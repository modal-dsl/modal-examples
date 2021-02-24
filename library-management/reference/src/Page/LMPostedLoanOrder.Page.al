page 50029 "LM Posted Loan Order"
{
    Caption = 'Posted Loan Order';
    InsertAllowed = false;
    Editable = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Posted Loan Order,Correct,Print/Send,Navigate';
    RefreshOnActivate = true;
    SourceTable = "LM Posted Loan Order Header";

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
                field("Book No."; "Book No.")
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
                field("Library User Code"; "Library User Code")
                {
                	ApplicationArea = All;
                }
                field("Loan Start"; "Loan Start")
                {
                	ApplicationArea = All;
                }
                field("Loan End"; "Loan End")
                {
                	ApplicationArea = All;
                }
            }
            part("LM Posted Loan Ord. Subf."; "LM Posted Loan Ord. Subf.")
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
            group("Posted Loan Order")
            {
                Caption = 'Posted Loan Order';
                Image = "Order";
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "LM Book Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Posted Loan Order"),
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
