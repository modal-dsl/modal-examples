page 50010 "FM Wrk. Ord. Subf."
{

    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "FM Wrk. Ord. Line";

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
                field("Cost Type"; "Cost Type")
                {
                	ApplicationArea = All;
                }
                field(Description; Description)
                {
                	ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                	ApplicationArea = All;
                }
                field(Amount; Amount)
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
