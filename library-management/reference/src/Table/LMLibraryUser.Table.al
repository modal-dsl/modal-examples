table 50023 "LM Library User" {
	Caption = 'Library User';
	DataCaptionFields = Name, Code;
	LookupPageId = "LM Library Users";
	
	fields
	{
		field(1; "Code"; Code[10])
		{
			Caption = 'Code';
			NotBlank = true;
		}
		field(2; "Name"; Text[100])
		{
			Caption = 'Name';
			
			trigger OnValidate()
			begin
				if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then
					"Search Name" := CopyStr(Name, 1, MaxStrLen("Search Name"));
			end;
		}
		field(3; "Search Name"; Code[100])
		{
			Caption = 'Search Name';
		}
		field(4; "Name 2"; Text[50])
		{
			Caption = 'Name 2';
		}
		field(5; Blocked; Boolean)
		{
			Caption = 'Blocked';
		}
	}
	
	keys
	{
		key(Key1; "Code")
		{
			Clustered = true;
		}
		key(Key2; "Search Name") { }
	}
	
	fieldgroups
	{
		fieldgroup(DropDown; Name, "Name 2") { }
	}
	
	var
	
	procedure TestBlocked()
	begin
		TestField(Blocked, false);
	end;
}
