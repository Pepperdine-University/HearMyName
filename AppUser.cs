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
    
    public partial class AppUser
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public AppUser()
        {
            this.AppEvents = new HashSet<AppEvent>();
        }
    
        public int ID { get; set; }
        public string UserName { get; set; }
        public Nullable<int> UserRoleID { get; set; }
        public Nullable<int> UserCWID { get; set; }
    
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<AppEvent> AppEvents { get; set; }
        public virtual UserRole UserRole { get; set; }
    }
}
