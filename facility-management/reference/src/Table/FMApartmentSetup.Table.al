table 50000 "FM Apartment Setup"
{
    Caption = 'Apartment Setup';
    DrillDownPageID = "FM Apartment Setup";
    LookupPageID = "FM Apartment Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Apartment Nos."; Code[20])
        {
            Caption = 'Apartment Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Wrk. Ord. Nos."; Code[20])
        {
        	Caption = 'Wrk. Ord. Nos.';
        	TableRelation = "No. Series";
        }
        field(4; "Posted Wrk. Ord. Nos."; Code[20])
        {
        	Caption = 'Posted Wrk. Ord. Nos.';
        	TableRelation = "No. Series";
        }
        field(10; "Copy Comments"; Boolean)
        {
        	AccessByPermission = TableData "FM Posted Work Order Header" = R;
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
