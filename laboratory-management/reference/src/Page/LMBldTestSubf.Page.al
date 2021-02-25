page 50049 "LM Bld. Test Subf."
{

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "LM Bld. Test Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                
                field("Line No."; "Line No.")
                {
                	ApplicationArea = All;
                	ToolTip = 'Specifies the number of the line.';
                	Visible = false;
                }
                field(Description; Description)
                {
                	ApplicationArea = All;
                }
                field(Measurement; Measurement)
                {
                	ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                group("Related Information")
                {
                    Caption = 'Related Information';
                    action("Co&mments")
                    {
                        ApplicationArea = Comments;
                        Caption = 'Co&mments';
                        Image = ViewComments;
                        ToolTip = 'View or add comments for the record.';

                        trigger OnAction()
                        begin
                            ShowLineComments;
                        end;
                    }
                }
            }
        }
    }
}
