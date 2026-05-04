import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/features/coupons/domain/coupons_repository.dart';
import 'package:truce/features/coupons/domain/models.dart';

abstract class CouponsState {}
class CouponsInitial extends CouponsState {}
class CouponsLoading extends CouponsState {}
class CouponsLoaded extends CouponsState {
  final List<Coupon> coupons;
  CouponsLoaded(this.coupons);
}
class CouponsError extends CouponsState {
  final String message;
  CouponsError(this.message);
}

class CouponsCubit extends Cubit<CouponsState> {
  final CouponsRepository _repository;
  CouponsCubit(this._repository) : super(CouponsInitial());

  Future<void> loadCoupons() async {
    emit(CouponsLoading());
    final (failure, coupons) = await _repository.getCoupons();
    if (failure != null) {
      emit(CouponsError(failure.message));
    } else {
      emit(CouponsLoaded(coupons ?? []));
    }
  }
}
