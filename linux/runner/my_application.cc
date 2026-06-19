#include "my_application.h"

#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <flutter_linux/flutter_linux.h>
#include <glib-object.h>
#include <cstring>

#include "generated_plugin_registrant.cc"

struct _MyApplication {
  GtkApplication parent_instance;
  char *dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static gboolean my_application_local_command_line(GApplication *application, gchar **arguments, gint *exit_status) {
  MyApplication *self = MY_APPLICATION(application);
  g_strfreev(self->dart_entrypoint_arguments);
  self->dart_entrypoint_arguments = g_strdupv(arguments);

  GApplicationClass *parent_class = G_APPLICATION_CLASS(my_application_parent_class);
  return parent_class->local_command_line(application, arguments, exit_status);
}

static void my_application_activate(GApplication *application) {
  MyApplication *self = MY_APPLICATION(application);

  GtkWidget *window = gtk_application_window_new(GTK_APPLICATION(application));
  GtkWindow *gtk_window = GTK_WINDOW(window);
  gtk_window_set_title(gtk_window, "yuedu_app");
  gtk_window_set_default_size(gtk_window, 1280, 720);

  gtk_widget_show(window);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  FlView *view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_engine_start(fl_view_get_engine(view));
}

static void my_application_class_init(MyApplicationClass *klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
}

static void my_application_init(MyApplication *self) {}

MyApplication *my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(), "application-id", G_APPLICATION_ID, "flags", G_APPLICATION_HANDLES_COMMAND_LINE, nullptr));
}
