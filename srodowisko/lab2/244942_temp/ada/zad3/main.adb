with Ada.Text_IO;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
with Settings;
use Ada.Text_IO;

procedure Main is
   Subtype Integer_Range is Integer range 0 .. 1023;
   subtype AdditionMachines_Range is Integer range 1 .. Settings.AdditionMachines;
   subtype MultiplicationMachines_Range is Integer range 1 .. Settings.MultiplicationMachines;
   type Binary_Range is new Integer Range 0 .. 1;
   subtype Worker_Range is Integer range 1 .. Settings.Workers;
   type Integer_Access is access Integer;

   Type Job is record
      FirstArg : Integer;
      SecondArg : Integer;
      Operand : Character;
      Result : Integer_Access;
   end record;

   package Job_Lists is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => Job);

   package Integer_Lists is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => Integer);

   package Boss_Integer_Random is new Ada.Numerics.Discrete_Random
     (Result_Subtype => Integer_Range);

   package Binary_Random is new Ada.Numerics.Discrete_Random
     (Result_Subtype => Binary_Range);

   package Addition_Random is new Ada.Numerics.Discrete_Random
     (Result_Subtype => AdditionMachines_Range);

   package Multiplication_Random is new Ada.Numerics.Discrete_Random
     (Result_Subtype => MultiplicationMachines_Range);

   task type Boss;
   task type Client;
   task type AssignWorkers;
   task type AdditionMachine is
      entry Calculate(J : in out Job);
      entry Repair;
   end AdditionMachine;
   task type MultiplicationMachine is
      entry Calculate(J : in out Job);
      entry Repair;
   end MultiplicationMachine;

   type Boolean_Array is array (Positive range <>) of Boolean;
   type AdditionMachine_Access is access AdditionMachine;
   type MultiplicationMachine_Access is access MultiplicationMachine;
   type AdditionMachine_Access_Array is array (AdditionMachines_Range) of AdditionMachine_Access;
   type MultiplicationMachine_Access_Array is array (MultiplicationMachines_Range) of MultiplicationMachine_Access;
   type AdditionMachine_Access_Array_Access is access AdditionMachine_Access_Array;
   type MultiplicationMachine_Access_Array_Access is access MultiplicationMachine_Access_Array;
   Patient_Workers : array (Worker_Range) of Boolean;
   Job_Counts : array (Worker_Range) of Integer;

   task type Worker(Id : Integer; Adds : AdditionMachine_Access_Array_Access; Mults : MultiplicationMachine_Access_Array_Access);
   type Worker_Access is access Worker;
   task type MaintenanceWorker (Id : Integer; M : Integer; Adds : AdditionMachine_Access_Array_Access; Mults : MultiplicationMachine_Access_Array_Access);

   type MaintenanceWorker_Access is access MaintenanceWorker;

   type MaintenanceWorker_Access_Array is array (Positive range <>) of MaintenanceWorker_Access;

   package MaintenanceWorker_Lists is new Ada.Containers.Doubly_Linked_Lists
     (Element_Type => MaintenanceWorker_Access);

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

   protected Maintenance is
      procedure Initiate(AM : In AdditionMachine_Access_Array_Access; MM : in MultiplicationMachine_Access_Array_Access);
      procedure CheckIn (I : in Integer; M : Integer);
      procedure Report (M : in Integer);
   private
      Ams : AdditionMachine_Access_Array_Access;
      Mms : MultiplicationMachine_Access_Array_Access;
      Workers : MaintenanceWorker_Access_Array (1 .. Settings.MaintenanceWorkers);
      AvailableWorkers : Integer_Lists.List;
      InRepair : Boolean_Array (1 .. Settings.AdditionMachines + Settings.MultiplicationMachines);
      Reports : Integer_Lists.List;
   end Maintenance;

   task body Boss is
      NewJob : Job;
      IntGen : Boss_Integer_Random.Generator;
      OpGen : Binary_Random.Generator;
      VarGen : Ada.Numerics.Float_Random.Generator;
   begin
      Boss_Integer_Random.Reset(IntGen);
      Binary_Random.Reset(OpGen);
      Ada.Numerics.Float_Random.Reset(VarGen);
      loop
         NewJob.FirstArg := Boss_Integer_Random.Random(IntGen);
         NewJob.SecondArg := Boss_Integer_Random.Random(IntGen);
         NewJob.Operand := (case Binary_Random.Random(OpGen) is
            when 0 => '+',
                               when 1 => '*');
         NewJob.Result := null;
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
      VarGen : Ada.Numerics.Float_Random.Generator;
      BinGen : Binary_Random.Generator;
      AddGen : Addition_Random.Generator;
      MulGen : Multiplication_Random.Generator;
      Done : Boolean;
      M : Integer;
   begin
      Ada.Numerics.Float_Random.Reset(VarGen);
      Binary_Random.Reset(BinGen);
      Addition_Random.Reset(Gen => AddGen);
      Multiplication_Random.Reset(Gen => MulGen);
      Patient_Workers(Id) := (Binary_Random.Random(BinGen) = 1);
      Job_Counts(Id) := 0;
      loop
         JobList.Get(CurrJob);
         case CurrJob.Operand is
            when '+' =>
               while CurrJob.Result = null loop
                  M := Addition_Random.Random(Gen => AddGen);
                  if Patient_Workers(Id)
                  then
                     Adds.all(M).all.Calculate(CurrJob);
                  else
                     Done := False;
                     while not Done loop
                        select
                           Adds.all(M).all.Calculate(CurrJob);
                           Done := True;
                        or
                           delay Duration(Settings.ImpatientWait);
                           M := Addition_Random.Random(Gen => AddGen);
                        end select;
                     end loop;
                  end if;
                  if CurrJob.Result = null
                  then
                     Maintenance.Report(M => M);
                  end if;
               end loop;
            when '*' =>
               while CurrJob.Result = null loop
                  M := Multiplication_Random.Random(Gen => MulGen);
                  if Patient_Workers(Id)
                  then
                     Mults.all(M).all.Calculate(CurrJob);
                  else
                     Done := False;
                     while not Done loop
                        select
                           Mults.all(M).all.Calculate(CurrJob);
                           Done := True;
                        or
                           delay Duration(Settings.ImpatientWait);
                           M := Multiplication_Random.Random(Gen => MulGen);
                        end select;
                     end loop;
                  end if;
                  if CurrJob.Result = null
                  then
                     Maintenance.Report(M => Settings.AdditionMachines + M);
                  end if;
               end loop;
            when others =>
               null;
         end case;
         Warehouse.Add(P => CurrJob.Result.All);
         Job_Counts(Id) := Job_Counts(Id) + 1;
         if Settings.LoudMode
         then
            Put_Line("Worker " & Integer'Image(Id) & ":" & Integer'Image(CurrJob.FirstArg) & " " & CurrJob.Operand & Integer'Image(CurrJob.SecondArg) & " =" & Integer'Image(CurrJob.Result.all));
         end if;
         --delay Duration(Settings.WorkerDelay * (1.0 + Settings.WorkerVariance * (2.0 * Ada.Numerics.Float_Random.Random(VarGen) - 1.0)));
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

   task body AdditionMachine is
      Broken : Boolean;
      Gen : Ada.Numerics.Float_Random.Generator;
   begin
      Broken := False;
      Ada.Numerics.Float_Random.Reset(Gen => Gen);
      loop
         select
            accept Repair do
               if Broken
               then
                  delay Duration(Settings.RepairTime);
                  Broken := False;
               end if;
            end Repair;
         or
            accept Calculate (J : in out Job) do
               delay Duration(Settings.MachineWorkTime);
               if not Broken
               then
                  J.Result := new Integer'(J.FirstArg + J.SecondArg);
                  if Ada.Numerics.Float_Random.Random(Gen => Gen) < Settings.BreakChance
                  then
                     Broken := True;
                  end if;
               end if;
            end Calculate;
         end select;
      end loop;
   end AdditionMachine;

   task body MultiplicationMachine is
      Broken : Boolean;
      Gen : Ada.Numerics.Float_Random.Generator;
   begin
      Broken := False;
      Ada.Numerics.Float_Random.Reset(Gen => Gen);
      loop
         select
            accept Repair do
               if Broken
               then
                  delay Duration(Settings.RepairTime);
                  Broken := False;
               end if;
            end Repair;
         or
            accept Calculate (J : in out Job) do
               delay Duration(Settings.MachineWorkTime);
               if not Broken
               then
                  J.Result := new Integer'(J.FirstArg * J.SecondArg);
                  if Ada.Numerics.Float_Random.Random(Gen => Gen) < Settings.BreakChance
                  then
                     Broken := True;
                  end if;
               end if;
            end Calculate;
         end select;
      end loop;
   end MultiplicationMachine;

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

   protected body Maintenance is

      procedure Initiate (AM : In AdditionMachine_Access_Array_Access; MM : in MultiplicationMachine_Access_Array_Access) is
      begin
         Ams := AM;
         Mms := MM;
         for I in 1 .. Settings.MaintenanceWorkers loop
            AvailableWorkers.Append(I);
         end loop;
         for I in 1 .. Settings.AdditionMachines + Settings.MultiplicationMachines loop
            InRepair(I) := False;
         end loop;
      end Initiate;

      procedure CheckIn(I : in Integer; M : in Integer) is
      begin
         InRepair(M) := False;
         while (not Reports.Is_Empty) and InRepair(Reports.First_Element) loop
            Reports.Delete_First;
         end loop;
         if not Reports.Is_Empty
         then
            if Settings.LoudMode
            then
               Put_Line("Maintenance: sending repair to" & Integer'Image(Reports.First_Element));
            end if;
            Workers(I) := new MaintenanceWorker(I,Reports.First_Element,Ams,Mms);
            InRepair(Reports.First_Element) := True;
            Reports.Delete_First;
         else
            AvailableWorkers.Append(I);
         end if;
      end CheckIn;

      procedure Report(M : in Integer) is
      begin
         if not InRepair(M)
         then
            if not AvailableWorkers.Is_Empty
            then
               if Settings.LoudMode
               then
                  Put_Line("Maintenance: sending repair to" & Integer'Image(M));
               end if;
               Workers(AvailableWorkers.First_Element) := new MaintenanceWorker(AvailableWorkers.First_Element,M,Ams,Mms);
               AvailableWorkers.Delete_First;
               InRepair(M) := True;
            else
               Reports.Append(M);
            end if;
         end if;
      end Report;

   end Maintenance;

   task body MaintenanceWorker is
   begin
      --Put_Line("Maintenance worker" & Integer'Image(Id) & " going to repair" & Integer'Image(M));
      delay Duration(Settings.MaintenanceArrivalTime);
      if M > Settings.AdditionMachines
      then
         Mults.all(M - Settings.AdditionMachines).all.Repair;
      else
         Adds.all(M).all.Repair;
      end if;
      --Put_Line("Maintenance worker" & Integer'Image(Id) & " done");
      Maintenance.CheckIn(I => Id,
                          M => M);
   end MaintenanceWorker;

   task body AssignWorkers is
      type Worker_Access_Array is array (1 .. Settings.Workers) of Worker_Access;
      Workers : Worker_Access_Array;
      Adds : AdditionMachine_Access_Array_Access;
      Mults : MultiplicationMachine_Access_Array_Access;
   begin
      Adds := new AdditionMachine_Access_Array;
      Mults := new MultiplicationMachine_Access_Array;
      for I in AdditionMachines_Range loop
         Adds.all(I) := new AdditionMachine;
      end loop;
      for I in MultiplicationMachines_Range loop
         Mults.all(I) := new MultiplicationMachine;
      end loop;
      Maintenance.Initiate(AM => Adds,
                           MM => Mults);
      for I in 1 .. Settings.Workers loop
         Workers(I) := new Worker(I,Adds,Mults);
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
         elsif L = "w"
         then
            for I in Worker_Range loop
               Put_Line("Worker " & Integer'Image(I) & ": patient -" & Boolean'Image(Patient_Workers(I)) & ", jobs completed -" & Integer'Image(Job_Counts(I)));
            end loop;
         else
            Put_Line("unrecognized command");
         end If;
      end loop;
   end if;
end Main;
