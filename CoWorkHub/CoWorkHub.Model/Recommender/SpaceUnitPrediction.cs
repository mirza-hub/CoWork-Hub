using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Recommender
{
    public class SpaceUnitPrediction
    {
        [ColumnName("Features")]    
        public float[] Features { get; set; }

        public int SpaceUnitId { get; set; }
        public float Score { get; set; }
        public string Name { get; set; }
        public float PricePerDay { get; set; }
    }
}
