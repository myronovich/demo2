provider "google" {

  credentials = file("credentials.json")

  project     = "gcp101233-lv61301devops"

  region      = "us-central1"

}

####################################

resource "google_compute_address" "extipmain" {

  name = "extipmain"

}

######################################

resource "google_compute_instance" "default10" {

  name         = "mainmachine"

  machine_type = "e2-standard-4"

  zone         = "us-central1-a"



  metadata_startup_script = templatefile("${path.module}/docker.sh", {

  dbpass = data.google_secret_manager_secret_version.postgres.secret_data

  })



  tags                    = ["foo", "bar"]



  boot_disk {

    initialize_params {

      image = "ubuntu-os-cloud/ubuntu-2004-lts"

    }

  }

  

   network_interface {

    network = "default"

    access_config {

      nat_ip = google_compute_address.extipmain.address

    }

  }

  metadata = {

    foo = "bar"

  }



data "google_secret_manager_secret_version" "postgres" { 

   secret = "postgres"

}



}



####################################

resource "google_compute_address" "extipslave" {

  name = "extipslave"

}

resource "google_compute_instance" "default11" {

  name         = "slavemachine"

  machine_type = "e2-standard-2"

  zone         = "us-central1-a"

  

  metadata_startup_script = templatefile("${path.module}/dockerr.sh", {

  dbpass          = data.google_secret_manager_secret_version.postgres.secret_data

  MY_PASSWORD     = data.google_secret_manager_secret_version.MY_PASSWORD.secret_data

  DATASOURCE_USER = data.google_secret_manager_secret_version.DATASOURCE_USER.secret_data

  DATASOURCE_URL = data.google_secret_manager_secret_version.DATASOURCE_URL.secret_data

  JWT_SECRET      = data.google_secret_manager_secret_version.JWT_SECRET.secret_data

  })

 

  tags = ["foo", "bar"]

  boot_disk {

    initialize_params {

      image = "ubuntu-os-cloud/ubuntu-2004-lts"

    }

  }



  network_interface {

    network = "default"

                        access_config {

    nat_ip = "${google_compute_address.extipslave.address}"

    }

  }

  metadata = {

    foo = "bar"

  }



data "google_secret_manager_secret_version" "postgres" {

  secret = "postgres"

}

data "google_secret_manager_secret_version" "MY_PASSWORD" {

  secret = "MY_PASSWORD"

}

data "google_secret_manager_secret_version" "JWT_SECRET" {

  secret = "JWT_SECRET"

}

data "google_secret_manager_secret_version" "DATASOURCE_USER" {

  secret = "DATASOURCE_USER"

}

data "google_secret_manager_secret_version" "DATASOURCE_URL" { 

  secret = "DATASOURCE_URL"

}



}
