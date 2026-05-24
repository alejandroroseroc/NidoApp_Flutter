-- Renombrar duracionMeses a duracionDias conservando todos los datos y la constraint NOT NULL
ALTER TABLE "Reserva" RENAME COLUMN "duracionMeses" TO "duracionDias";
