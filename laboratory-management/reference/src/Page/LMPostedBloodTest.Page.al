page 50048 "LM Posted Blood Test"
{
    Caption = 'Posted Blood Test';
    InsertAllowed = false;
    Editable = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Posted Blood Test,Correct,Print/Send,Navigate';
    RefreshOnActivate = true;
    SourceTable = "LM Posted Blood Test Header";

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
                field("Patient No."; "Patient No.")
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
            }
            part("LM Posted Bld. Test Subf."; "LM Posted Bld. Test Subf.")
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
            group("Posted Blood Test")
            {
                Caption = 'Posted Blood Test';
                Image = "Order";
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "LM Patient Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Posted Blood Test"),
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
