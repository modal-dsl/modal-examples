table 50027 "LM Posted Loan Order Line"
{
	Caption = 'LM Posted Loan Order Line';
	
    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "LM Loan Ord. Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Event Date"; Date)
        {
        	Caption = 'Event Date';
        }
        field(4; "Event Type"; Enum "LM Event Type")
        {
        	Caption = 'Event Type';
        }
        field(5; Description; Text[50])
        {
        	Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var
        BookCommentLine: Record "LM Book Comment Line";

    trigger OnDelete()
    begin
        BookCommentLine.SetRange("Document Type", BookCommentLine."Document Type"::"Posted Loan Order");
        BookCommentLine.SetRange("No.", "Document No.");
        BookCommentLine.SetRange("Line No.", "Line No.");
        BookCommentLine.DeleteAll();
    end;
    
	procedure ShowLineComments()
	var
		BookCommentLine: Record "LM Book Comment Line";
	begin
		BookCommentLine.ShowComments(BookCommentLine."Document Type"::"Posted Loan Order", "Document No.", "Line No.");
	end;
}
