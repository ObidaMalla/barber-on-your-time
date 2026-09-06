/*
  Warnings:

  - A unique constraint covering the columns `[staffId,date]` on the table `Availability` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `date` to the `Availability` table without a default value. This is not possible if the table is not empty.
  - Added the required column `date` to the `AvailabilityChangeRequest` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Availability" ADD COLUMN     "date" DATE NOT NULL;

-- AlterTable
ALTER TABLE "AvailabilityChangeRequest" ADD COLUMN     "date" DATE NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Availability_staffId_date_key" ON "Availability"("staffId", "date");
