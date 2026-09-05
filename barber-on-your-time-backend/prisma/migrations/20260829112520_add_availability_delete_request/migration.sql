-- CreateEnum
CREATE TYPE "RequestType" AS ENUM ('ADD', 'DELETE');

-- AlterTable
ALTER TABLE "AvailabilityChangeRequest" ADD COLUMN     "availabilityId" INTEGER,
ADD COLUMN     "type" "RequestType" NOT NULL DEFAULT 'ADD';

-- AddForeignKey
ALTER TABLE "AvailabilityChangeRequest" ADD CONSTRAINT "AvailabilityChangeRequest_availabilityId_fkey" FOREIGN KEY ("availabilityId") REFERENCES "Availability"("id") ON DELETE SET NULL ON UPDATE CASCADE;
