-- AlterTable
ALTER TABLE "Usuario" ADD COLUMN     "esFumador" BOOLEAN,
ADD COLUMN     "genero" TEXT,
ADD COLUMN     "nivelRuido" TEXT,
ADD COLUMN     "otrasPreferencias" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "tieneMascotas" BOOLEAN;
