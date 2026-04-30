-- CreateEnum
CREATE TYPE "ModoActivo" AS ENUM ('INVITADO', 'ANFITRION');

-- CreateEnum
CREATE TYPE "EstadoReserva" AS ENUM ('PENDIENTE', 'ACEPTADA', 'RECHAZADA');

-- CreateEnum
CREATE TYPE "TipoEspacio" AS ENUM ('HABITACION', 'APARTAESTUDIO', 'COMPARTIDO');

-- CreateEnum
CREATE TYPE "TipoPrivacidad" AS ENUM ('PRIVADO', 'COMPARTIDO');

-- CreateEnum
CREATE TYPE "EstadoAlojamiento" AS ENUM ('ACTIVO', 'INACTIVO');

-- CreateTable
CREATE TABLE "Usuario" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "correo" TEXT NOT NULL,
    "telefono" TEXT,
    "fotoPerfil" TEXT,
    "modoActivo" "ModoActivo" NOT NULL DEFAULT 'INVITADO',
    "contrasena" TEXT NOT NULL,
    "fechaRegistro" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Usuario_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PerfilConvivencia" (
    "id" TEXT NOT NULL,
    "aceptaMascotas" BOOLEAN NOT NULL DEFAULT false,
    "fumador" BOOLEAN NOT NULL DEFAULT false,
    "horarioRuido" TEXT,
    "preferenciaGenero" TEXT,
    "descripcionAdicional" TEXT,
    "usuarioId" TEXT NOT NULL,

    CONSTRAINT "PerfilConvivencia_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Alojamiento" (
    "id" TEXT NOT NULL,
    "titulo" TEXT NOT NULL,
    "descripcion" TEXT NOT NULL,
    "tipoEspacio" "TipoEspacio" NOT NULL,
    "tipoPrivacidad" "TipoPrivacidad" NOT NULL,
    "tipoAcceso" TEXT NOT NULL,
    "reglas" TEXT,
    "precio" DOUBLE PRECISION NOT NULL,
    "ubicacion" TEXT NOT NULL,
    "fotografias" TEXT[],
    "estado" "EstadoAlojamiento" NOT NULL DEFAULT 'ACTIVO',
    "anfitrionId" TEXT NOT NULL,
    "creadoEn" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Alojamiento_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Servicio" (
    "id" TEXT NOT NULL,
    "nombre" TEXT NOT NULL,
    "descripcion" TEXT,
    "alojamientoId" TEXT NOT NULL,

    CONSTRAINT "Servicio_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reserva" (
    "id" TEXT NOT NULL,
    "fechaIngreso" TIMESTAMP(3) NOT NULL,
    "duracionMeses" INTEGER NOT NULL,
    "estado" "EstadoReserva" NOT NULL DEFAULT 'PENDIENTE',
    "fechaSolicitud" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "invitadoId" TEXT NOT NULL,
    "alojamientoId" TEXT NOT NULL,

    CONSTRAINT "Reserva_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Resena" (
    "id" TEXT NOT NULL,
    "calificacion" INTEGER NOT NULL,
    "comentario" TEXT,
    "fecha" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "autorId" TEXT NOT NULL,
    "alojamientoId" TEXT NOT NULL,

    CONSTRAINT "Resena_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Usuario_correo_key" ON "Usuario"("correo");

-- CreateIndex
CREATE UNIQUE INDEX "PerfilConvivencia_usuarioId_key" ON "PerfilConvivencia"("usuarioId");

-- AddForeignKey
ALTER TABLE "PerfilConvivencia" ADD CONSTRAINT "PerfilConvivencia_usuarioId_fkey" FOREIGN KEY ("usuarioId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Alojamiento" ADD CONSTRAINT "Alojamiento_anfitrionId_fkey" FOREIGN KEY ("anfitrionId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Servicio" ADD CONSTRAINT "Servicio_alojamientoId_fkey" FOREIGN KEY ("alojamientoId") REFERENCES "Alojamiento"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reserva" ADD CONSTRAINT "Reserva_invitadoId_fkey" FOREIGN KEY ("invitadoId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reserva" ADD CONSTRAINT "Reserva_alojamientoId_fkey" FOREIGN KEY ("alojamientoId") REFERENCES "Alojamiento"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Resena" ADD CONSTRAINT "Resena_autorId_fkey" FOREIGN KEY ("autorId") REFERENCES "Usuario"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Resena" ADD CONSTRAINT "Resena_alojamientoId_fkey" FOREIGN KEY ("alojamientoId") REFERENCES "Alojamiento"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
