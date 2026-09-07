-- AlterEnum
ALTER TYPE "BookingStatus" ADD VALUE 'COMPLETED';

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "NotificationType" ADD VALUE 'BOOKING_CODE';
ALTER TYPE "NotificationType" ADD VALUE 'BOOKING_COMPLETION_REQUESTED';
ALTER TYPE "NotificationType" ADD VALUE 'BOOKING_COMPLETED';

-- AlterTable
ALTER TABLE "Booking" ADD COLUMN     "completionCode" TEXT;
