package settings is

   LoudMode : constant Boolean := False;
   Workers : constant Integer := 4;
   BossDelay : constant Float := 1.0;
   BossVariance : constant Float := 0.2;
   WorkerDelay : constant Float := 4.0;
   WorkerVariance : constant Float := 0.6;
   ClientDelay : constant Float := 1.0;
   ClientVariance : constant Float := 0.3;
   JobThreshold : constant Integer := 10;
   WarehouseThreshold : constant Integer := 15;

end settings;
