table 50040 "LM Patient Setup"
{
    Caption = 'Patient Setup';
    DrillDownPageID = "LM Patient Setup";
    LookupPageID = "LM Patient Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Patient Nos."; Code[20])
        {
            Caption = 'Patient Nos.';
            TableRelation = "No. Series";
        }
        field(3; "Bld. Test Nos."; Code[20])
        {
        	Caption = 'Bld. Test Nos.';
        	TableRelation = "No. Series";
        }
        field(4; "Posted Bld. Test Nos."; Code[20])
        {
        	Caption = 'Posted Bld. Test Nos.';
        	TableRelation = "No. Series";
        }
        field(10; "Copy Comments"; Boolean)
        {
        	AccessByPermission = TableData "LM Posted Blood Test Header" = R;
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
