variable "vm_count" {
  description = "Numărul de mașini virtuale de creat"
  default     = 3
}

variable "vm_size" {
  description = "Dimensiunea mașinii virtuale"
  default     = "Standard_B1s"
}

variable "vm_image" {
  description = "Imaginea pentru sistemul de operare al mașinii virtuale"
  default     = "22_04-lts"
}
