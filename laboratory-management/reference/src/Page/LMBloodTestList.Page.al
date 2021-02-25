page 50045 "LM Blood Test List"
{
    ApplicationArea = All;
    Caption = 'Blood Tests';
    CardPageID = "LM Blood Test";
    DataCaptionFields = "Patient No.";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Posting,Print/Send,Blood Test,Navigate';
    SourceTable = "LM Bld. Test Header";
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
            group("Blood Test")
            {
                Caption = 'Blood Test';
                Image = "Order";
                action("&Patient Card")
                {
                    ApplicationArea = All;
                    Caption = '&Patient Card';
                    RunObject = Page "LM Patient Card";
                    RunPageLink = "No." = FIELD("Patient No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View detailed information about the Patient.';
                }
                action(Comments)
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "LM Patient Comment Sheet";
                    RunPageLink = "Document Type" = CONST("Blood Test"),
                    			  "No." = field("No."),
                                  "Document Line No." = const(0);
                    ToolTip = 'View or add comments for the record.';
                }
            }
        }
    }
}
