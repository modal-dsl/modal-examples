page 50047 "LM Posted Blood Test List"
{
    ApplicationArea = All;
    Caption = 'Posted Blood Tests';
    CardPageID = "LM Posted Blood Test";
    DataCaptionFields = "Patient No.";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Posted Blood Test,Navigate,Print/Send';
    RefreshOnActivate = true;
    SourceTable = "LM Posted Blood Test Header";
    SourceTableView = SORTING("Posting Date")
   	                  ORDER(Descending);
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
            	ShowCaption = false;
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
                field("Patient No."; "Patient No.")
                {
                    ApplicationArea = All;
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
            group("Posted Blood Test")
            {
                Caption = 'Posted Blood Test';
                action(Comments)
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
        		CaptionML = DEU = '&Navigate',
        					ENU = '&Navigate';
        		Image = Navigate;
        		Promoted = true;
        		PromotedCategory = Process;
        		
        		trigger OnAction()
        		begin
        			Navigate();
        		end;
        	}
        }
    }
}
