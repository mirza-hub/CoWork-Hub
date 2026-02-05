using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace CoWorkHub.Services.Migrations
{
    /// <inheritdoc />
    public partial class addMissingColumn : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "CodeHash",
                table: "PasswordResetRequests",
                newName: "Code");

            migrationBuilder.AddColumn<DateTime>(
                name: "DeletedAt",
                table: "PasswordResetRequests",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "PasswordResetRequests",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "PasswordResetRequests");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "PasswordResetRequests");

            migrationBuilder.RenameColumn(
                name: "Code",
                table: "PasswordResetRequests",
                newName: "CodeHash");
        }
    }
}
