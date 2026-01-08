using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CoWorkHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class updatedTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ProfileImageBase64",
                table: "Users");

            migrationBuilder.AddColumn<double>(
                name: "Latitude",
                table: "WorkingSpaces",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "Longitude",
                table: "WorkingSpaces",
                type: "float",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<byte[]>(
                name: "ProfileImage",
                table: "Users",
                type: "varbinary(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Latitude",
                table: "WorkingSpaces");

            migrationBuilder.DropColumn(
                name: "Longitude",
                table: "WorkingSpaces");

            migrationBuilder.DropColumn(
                name: "ProfileImage",
                table: "Users");

            migrationBuilder.AddColumn<string>(
                name: "ProfileImageBase64",
                table: "Users",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
