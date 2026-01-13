using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CoWorkHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateReviewTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Review_User",
                table: "Reviews");

            migrationBuilder.DropForeignKey(
                name: "FK_SpaceUnit_Reviews",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_SpaceUnitId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_UsersId",
                table: "Reviews");

            migrationBuilder.DropColumn(
                name: "SpaceUnitId",
                table: "Reviews");

            migrationBuilder.RenameColumn(
                name: "UsersId",
                table: "Reviews",
                newName: "ReservationId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_ReservationId",
                table: "Reviews",
                column: "ReservationId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Reviews_Reservations_ReservationId",
                table: "Reviews",
                column: "ReservationId",
                principalTable: "Reservations",
                principalColumn: "ReservationId",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Reviews_Reservations_ReservationId",
                table: "Reviews");

            migrationBuilder.DropIndex(
                name: "IX_Reviews_ReservationId",
                table: "Reviews");

            migrationBuilder.RenameColumn(
                name: "ReservationId",
                table: "Reviews",
                newName: "UsersId");

            migrationBuilder.AddColumn<int>(
                name: "SpaceUnitId",
                table: "Reviews",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_SpaceUnitId",
                table: "Reviews",
                column: "SpaceUnitId");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_UsersId",
                table: "Reviews",
                column: "UsersId");

            migrationBuilder.AddForeignKey(
                name: "FK_Review_User",
                table: "Reviews",
                column: "UsersId",
                principalTable: "Users",
                principalColumn: "UsersId");

            migrationBuilder.AddForeignKey(
                name: "FK_SpaceUnit_Reviews",
                table: "Reviews",
                column: "SpaceUnitId",
                principalTable: "SpaceUnits",
                principalColumn: "SpaceUnitId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
