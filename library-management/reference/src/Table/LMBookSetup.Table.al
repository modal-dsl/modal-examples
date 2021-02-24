table 50020 "LM Book Setup"
{
    Caption = 'Book Setup';
    DrillDownPageID = "LM Book Setup";
    LookupPageID = "LM Book Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Book Nos."; Code[20])
        {
            Caption = 'Book Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Loan Ord. Nos."; Code[20])
        {
        	Caption = 'Loan Ord. Nos.';
        	TableRelation = "No. Series";
        }
        field(4; "Posted Loan Ord. Nos."; Code[20])
        {
        	Caption = 'Posted Loan Ord. Nos.';
        	TableRelation = "No. Series";
        }
        field(10; "Copy Comments"; Boolean)
        {
        	AccessByPermission = TableData "LM Posted Loan Order Header" = R;
        	Caption = 'Copy Comments To Posted Reg.';
        	InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        Get;
        RecordHasBeenRead := true;
    end;
}
