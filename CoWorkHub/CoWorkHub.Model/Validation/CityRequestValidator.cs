using System;
using System.Collections.Generic;
using System.Text;
using CoWorkHub.Model.Requests;
using FluentValidation;

namespace CoWorkHub.Model.Validation
{
    public class CityRequestValidator : AbstractValidator<CityInsertRequest>
    {
        public CityRequestValidator()
        {
            RuleFor(x => x.CityName)
                .NotEmpty().WithMessage("City name is required.")
                .MaximumLength(100).WithMessage("City name cannot exceed 100 characters.");

            RuleFor(x => x.CountryId)
                .GreaterThan(0).WithMessage("CountryId must be greater than 0.");

            RuleFor(x => x.PostalCode)
                .NotEmpty().WithMessage("Postal code is required.")
                .MaximumLength(10).WithMessage("Postal code cannot exceed 10 characters.");
        }
    }
}
