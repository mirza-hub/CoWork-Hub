using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class PagedResult<T>
    {
        public IList<T> ResultList { get; set; }
        public int? Count { get; set; }
        public int? Page { get; set; }
        public int? PageSize { get; set; }
        public int? TotalPages { get; set; }
        public bool? HasPreviousPage { get; set; }
        public bool? HasNextPage { get; set; }
    }
}
