//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace HearMyName
{
    using System;
    using System.Collections.Generic;
    
    public partial class StudentRecording
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public StudentRecording()
        {
            this.AppEvents = new HashSet<AppEvent>();
        }
    
        public int ID { get; set; }
        public int StudentCWID { get; set; }
        public string StudentName { get; set; }
        public string StudentPreferredName { get; set; }
        public string StudentEmail { get; set; }
        public string Pronounciation { get; set; }
        public Nullable<System.DateTime> CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public string StudentNTID { get; set; }
        public Nullable<bool> isReviewed { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<AppEvent> AppEvents { get; set; }
    }
}
