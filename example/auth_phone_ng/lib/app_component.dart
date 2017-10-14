import 'package:angular/angular.dart';
import 'src/firebase_service.dart';
import 'src/register_form_component.dart';

@Component(
    selector: 'phone-auth',
    templateUrl: 'app_component.html',
    styleUrls: const ['app_component.css'],
    directives: const[RegisterFormComponent],
    providers: const [FirebaseService])
class AppComponent implements OnInit {
  final FirebaseService service;

  AppComponent(this.service);

  @override
  ngOnInit() {

  }
}
