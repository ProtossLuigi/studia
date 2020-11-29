with Ada.Text_IO;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Settings;
use Ada.Text_IO;

procedure Main is
   Subtype Integer_Range is Integer range 0 .. 1023;
   type Operand_Range is new Integer Range 0 .. 2;

   Type Job is record
      FirstArg : Integer;
      SecondArg : Integer;
      Operand : Character;
   end record;

   package Job_Lists is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => Job);

   package Integer_Lists is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => Integer);

   package Boss_Integer_Random is new Ada.Numerics.Discrete_Random
     (Result_Subtype => Integer_Range);

   package Boss_Operand_Random is new Ada.Numerics.Discrete_Random
     (Result_Subtype => Operand_Range);

   task type Boss;
   task type Worker(Id : Integer);
   task type Client;
   task type AssignWorkers;

   type Worker_Access is access Worker;

   protected JobList is
      procedure Display;
      entry Add (J : in Job);
      entry Get (J : out Job);
   private
      Jobs : Job_Lists.List;
   end JobList;

   protected Warehouse is
      procedure Display;
      entry Add (P : in Integer);
      entry GetRandom (P : out Integer);
   private
      Products : Integer_Lists.List;
   end Warehouse;

   task body Boss is
      NewJob : Job;
      IntGen : Boss_Integer_Random.Generator;
      OpGen : Boss_Operand_Random.Generator;
      VarGen : Ada.Numerics.Float_Random.Generator;
   begin
      Boss_Integer_Random.Reset(IntGen);
      Boss_Operand_Random.Reset(OpGen);
      Ada.Numerics.Float_Random.Reset(VarGen);
      loop
         NewJob.FirstArg := Boss_Integer_Random.Random(IntGen);
         NewJob.SecondArg := Boss_Integer_Random.Random(IntGen);
         NewJob.Operand := (case Boss_Operand_Random.Random(OpGen) is
            when 0 => '+',
            when 1 => '-',
            when 2 => '*');
         JobList.Add(NewJob);
         if Settings.LoudMode
         then
            Put_Line("Boss: " & Integer'Image(NewJob.FirstArg) & " " & NewJob.Operand & Integer'Image(NewJob.SecondArg));
         end if;
         delay Duration(Settings.BossDelay + Settings.BossDelay * Settings.BossVariance * (2.0 * Ada.Numerics.Float_Random.Random(VarGen) - 1.0));
      end loop;
   end Boss;

   task body Worker is
      CurrJob : Job;
      Product : Integer;
      VarGen : Ada.Numerics.Float_Random.Generator;
   begin
      Ada.Numerics.Float_Random.Reset(VarGen);
      loop
         JobList.Get(CurrJob);
         Product := (case CurrJob.Operand is
                        when '+' => CurrJob.FirstArg + CurrJob.SecondArg,
                        when '-' => CurrJob.FirstArg - CurrJob.SecondArg,
                        when '*' => CurrJob.FirstArg * CurrJob.SecondArg,
                        when others => 0);
         Warehouse.Add(Product);
         if Settings.LoudMode
         then
            Put_Line("Worker " & Integer'Image(Id) & ":" & Integer'Image(CurrJob.FirstArg) & " " & CurrJob.Operand & Integer'Image(CurrJob.SecondArg) & " =" & Integer'Image(Product));
         end if;
         delay Duration(Settings.WorkerDelay * (1.0 + Settings.WorkerVariance * (2.0 * Ada.Numerics.Float_Random.Random(VarGen) - 1.0)));
      end loop;
   end Worker;

   task body Client is
      VarGen : Ada.Numerics.Float_Random.Generator;
      Product : Integer;
   begin
      Ada.Numerics.Float_Random.Reset(VarGen);
      loop
         Warehouse.GetRandom(Product);
         if Settings.LoudMode
         then
            Put_Line("Client: " & Integer'Image(Product));
         end if;
         delay Duration(Settings.ClientDelay * (1.0 + Settings.ClientVariance * (2.0 * Ada.Numerics.Float_Random.Random(VarGen) - 1.0)));
      end loop;
   end Client;

   protected body JobList is

      procedure Display is
         Cur : Job_Lists.Cursor;
         CurJob : Job;
      begin
         if Jobs.Is_Empty
         then
            Put_Line("empty");
         else
            Cur := Jobs.First;
            while Job_Lists.Has_Element(Cur) loop
               CurJob := Job_Lists.Element(Cur);
               Put_Line(Integer'Image(CurJob.FirstArg) & " " & CurJob.Operand & Integer'Image(CurJob.SecondArg));
               Job_Lists.Next(Cur);
            end Loop;
         end if;
      end Display;

      entry Add(J : In Job)
        when Integer(Jobs.Length) < Settings.JobThreshold is
      begin
         Jobs.Append(J);
      end Add;

      entry Get (J : out Job)
        when not Jobs.Is_Empty is
      begin
         J := Jobs.First_Element;
         Jobs.Delete_First;
      end Get;

   end JobList;

   protected body Warehouse is

      procedure Display is
         Cur : Integer_Lists.Cursor;
      begin
         if Products.Is_Empty
         then
            Put_Line("empty");
         else
            Cur := Products.First;
            while Integer_Lists.Has_Element(Cur) loop
               Put_Line(Integer'Image(Integer_Lists.Element(Cur)));
               Integer_Lists.Next(Cur);
            end loop;
         End if;
      end Display;

      Entry Add (P : in Integer)
        when Integer(Products.Length) < Settings.WarehouseThreshold is
      begin
         Products.Append(P);
      end Add;

      entry GetRandom (P : out Integer)
        when not Products.Is_Empty is
         Gen : Boss_Integer_Random.Generator;
         I : Integer;
         Cur : Integer_Lists.Cursor;
      begin
         Boss_Integer_Random.Reset(Gen);
         Cur := Products.First;
         I := Boss_Integer_Random.Random(Gen) mod Integer(Products.Length);
         for J in 0 .. I-1 loop
            Integer_Lists.Next(Cur);
         end loop;
         P := Integer_Lists.Element(Cur);
         Products.Delete(Cur);
      end GetRandom;

   end Warehouse;

   task body AssignWorkers is
      type Worker_Access_Array is array (1 .. Settings.Workers) of Worker_Access;
      Workers : Worker_Access_Array;
   begin
      for I in 1 .. Settings.Workers loop
         Workers(I) := new Worker(I);
      end loop;
   end AssignWorkers;

   Assignment : AssignWorkers;
   Main_Boss : Boss;
   Main_Client : Client;

   L : String := " ";
begin
   if not Settings.LoudMode
   then
      loop
         --Put_Line("1");
         Get(L);
         --Put_Line("2");
         if L = "j"
         then
            JobList.Display;
         elsif L = "p"
         then
            Warehouse.Display;
         else
            Put_Line("unrecognized command");
         end If;
      end loop;
   end if;
end Main;
